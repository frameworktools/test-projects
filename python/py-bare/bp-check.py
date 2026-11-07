"""BP Check

A bare project has no folder structure, only settings.yml. This script shows the
smallest useful Framework workflow: scaffold, query the shared study database, and print
a summary.

Run it with: uv run python bp-check.py
"""

import framework as fw

fw.scaffold()


def main() -> None:
    fw.status()

    # The study connection is defined in settings.yml; the relative path
    # ../../shared/study.sqlite is resolved from the project root.
    means = fw.db_query(
        """
        SELECT p.treatment, v.visit_number, ROUND(AVG(v.systolic_bp), 1) AS mean_systolic
        FROM visits v JOIN participants p USING (participant_id)
        GROUP BY p.treatment, v.visit_number
        """,
        "study",
    )
    print("\nMean systolic BP by visit:")
    print(means.pivot(index="visit_number", columns="treatment", values="mean_systolic"))

    # Without a data or outputs folder there is nowhere configured to save to;
    # a bare project is for small jobs that only read.
    print("\nConfigured folders:", fw.settings("directories") or "(none)")


if __name__ == "__main__":
    main()
