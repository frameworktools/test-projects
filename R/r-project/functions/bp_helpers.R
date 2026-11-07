# Blood pressure helpers. scaffold() sources every file in functions/, so these
# are available in every notebook and script without a library() call.

#' Classify a blood pressure reading with the 2017 ACC/AHA categories
#'
#' @param systolic Systolic pressure in mmHg.
#' @param diastolic Diastolic pressure in mmHg.
#' @return An ordered factor: normal, elevated, stage 1, stage 2.
classify_bp <- function(systolic, diastolic) {
  category <- dplyr::case_when(
    is.na(systolic) | is.na(diastolic) ~ NA_character_,
    systolic >= 140 | diastolic >= 90 ~ "stage 2",
    systolic >= 130 | diastolic >= 80 ~ "stage 1",
    systolic >= 120 ~ "elevated",
    TRUE ~ "normal"
  )
  factor(category, levels = c("normal", "elevated", "stage 1", "stage 2"), ordered = TRUE)
}

#' Mean and 95% confidence interval of a numeric vector, ignoring missing values
#'
#' @param x Numeric vector.
#' @return A one-row data frame with n, mean, lower, and upper.
mean_ci <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  mean_x <- mean(x)
  half_width <- stats::qt(0.975, df = n - 1) * stats::sd(x) / sqrt(n)
  data.frame(n = n, mean = mean_x, lower = mean_x - half_width, upper = mean_x + half_width)
}
