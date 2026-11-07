* 07_cloud.do: Framework Cloud, shown without connecting to it.
*
* fw_login, fw_logout, and publishing to Cloud need a Framework Cloud account
* and a network connection, so they are commented out. Everything that runs
* here stays on this computer.

version 16
if `"$root"' != `"`c(pwd)'"' quietly do "settings.do"

* ---------------------------------------------------------------------------
* Connecting this computer
* ---------------------------------------------------------------------------

* fw_login shows a short code and opens the approval page in a browser. You
* sign in and approve the computer, and the token goes in the system keyring,
* where R, Python, and fw find it too. r(account) and r(stored) say who you
* are and where the token went (keyring or file). nobrowser prints the link
* instead of opening it; url() picks another server.
*   fw_login
*   fw_login, nobrowser
*   return list

* fw_logout revokes the token on the server and removes it from this
* computer. It names R's separate token file if one exists.
*   fw_logout

* After fw_login, fw_setup (without nonetwork) confirms the login over the
* network and shows the account.
*   fw_setup, nopython

* ---------------------------------------------------------------------------
* Publishing to Cloud
* ---------------------------------------------------------------------------

* fw_login connects the computer, not a project. Publishing a project to
* Cloud uses a project token in the project's .env file:
*   FW_PROJECT_TOKEN=<token from the project's page in Framework Cloud>
* Then to(cloud) uploads with curl:
*   fw_publish `"$outputs_figures/bp_by_visit.png"', to(cloud) visibility(unlisted)

* Without a project token, to(cloud) stops before sending anything, with
* error 677 and a message that says what to add to .env. This is safe to run.
capture noisily fw_publish `"$outputs_figures/bp_by_visit.png"', to(cloud)
display as text "to(cloud) without a project token returned " as result _rc

* With a project token in .env, every folder publish in 06_publish.do would
* also record the artifact's metadata in Cloud. The files stay in the folder.

* ---------------------------------------------------------------------------
* The integrity ledger
* ---------------------------------------------------------------------------

* With this in settings.yml, fw_save and fw_use, check(accept) also send each
* dataset's checksum, size, and this computer's name to Cloud (never the
* data), using the project token:
*   default:
*     options:
*       cloud_ledger: live
* The environment variable FW_LEDGER=off turns it off for a session.
