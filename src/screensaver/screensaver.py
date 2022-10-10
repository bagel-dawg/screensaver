import tempfile
import subprocess
import os
import logging
import shlex
import sys
import requests
import pyperclip

version = "0.0.0"

logger = logging.getLogger(__name__)
# Remove any default log handlers
# since we only want to log to stdout
for handler in logger.handlers:
    logger.removeHandler(handler)
# Set the log stream handlers for stdout
handler = logging.StreamHandler()
# Grab the logging level from environment var
# if not found, et log level to warning
log_level = os.environ.get('LOG_LEVEL', 'WARNING').upper()
logger.setLevel(log_level)
# Configure the format of the logs
formatter = logging.Formatter('{%(asctime)s:%(pathname)s:%(lineno)d} %(levelname)s - %(message)s', '%Y-%m-%d %H:%M:%S')
handler.setFormatter(formatter)
logger.addHandler(handler)

screenshot_cmd  = os.environ.get('SCREENSAVER_SCREENSHOT_CMD', "import")
browser_cmd     = os.environ.get('SCREENSAVER_BROWSER_CMD', "xdg-open")
screenshot_opts = os.environ.get('SCREENSAVER_SCREENSHOT_OPTS', "")
api_token       = os.environ.get('SCREENSAVER_X_API_TOKEN', "")
server_url      = os.environ.get('SCREENSAVER_SERVER_URL', 'https://webhooks.bageltech.io/upload')

tmpdir = tempfile.TemporaryDirectory()
logger.debug("tmpdir: {}".format(tmpdir.name))

logger.debug("Script version: {}".format(version))

def take_screenshot():
    logger.debug("take_screenshot()")

    cmd = "{command} {options} {path}/ss.png".format(command=screenshot_cmd, options=screenshot_opts, path=tmpdir.name)

    process = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    while True:
        output = process.stdout.readline()
        if output == b'' and process.poll() is not None:
            break
        if output:
            logger.debug(output.strip())
    process.communicate()
    if process.returncode != 0:
        logger.error('It seems the process did not exit with code 0, exiting script....')
        tmpdir.cleanup()
        sys.exit(1)

def get_image_data():
    logger.debug("get_image_data()")
    with open("{}/ss.png".format(tmpdir.name), "rb") as image_file:
        image = image_file.read()
    return image

def ship_screenshot():
    logger.debug("ship_screenshot()")

    data = get_image_data()

    logger.debug("Request data:")
    logger.debug(data)
    logger.debug("---")

    headers = {
      "User-Agent": 'screensaver/{}'.format(version),
      'Content-Type': 'application/octet-stream',
      "screensaver-api-token":  api_token
    }

    logger.debug("Request headers:")
    logger.debug(headers)
    logger.debug("---")

    logger.debug("Server URL: {}".format(server_url))
    r = requests.post(url=server_url, data=data, headers=headers)
    logger.debug(r.content)

    return r.content.decode("utf-8")

if __name__ == "__main__":
    logger.debug("main()")

    take_screenshot()
    link = ship_screenshot()
    pyperclip.copy(link)
    subprocess.Popen(shlex.split("{cmd} '{link}'".format(cmd=browser_cmd,link=link)), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    tmpdir.cleanup()
