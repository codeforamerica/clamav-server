# Virus Scanner Service
Deployable virus scanning service developed for use in applications using [form-flow](https://github.com/codeforamerica/form-flow). We use a modified version of [clammit Dockerfile](https://github.com/maxsivkov/clammit-docker), a lightweight HTTP wrapper around [ClamAV](https://www.clamav.net/). 

Clammit configuration parameters are passed through environment. Based on these variables launcher.sh creates [clamav.cfg configuration](https://github.com/ifad/clammit/blob/master/README.md#configuration) file

Environment variable         | Description
:---------------| :-----------------------------------------------------------------------------
CLAMMIT_LISTEN          | The listen address
CLAMMIT_CLAMD_URL       | The URL of the clamd server
CLAMMIT_APP_URL | (Optional) Forward all requests to this application
CLAMMIT_LOG_FILE        | (Optional) The clammit log file, if ommitted will log to stdout
CLAMMIT_TEST_PAGES      | (Optional) If true, clammit will also offer up a page to perform test uploads
CLAMMIT_DEBUG           | (Optional) If true, more things will be logged
CLAMMIT_STATUS_CODE      | (Optional) The HTTP status code to return when a virus is found. Default is 418 
CLAMMIT_MEMORY_THRESHOLD      | (Optional) If the body content-length exceeds this value, it will be written to disk. Below it, we'll hold the whole body in memory to improve speed. Default is 1Mb
CLAMMIT_THREADS      | (Optional) Number of CPU threads to use. Default is a number of CPUs cores 
