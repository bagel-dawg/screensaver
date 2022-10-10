# screensaver

## What is this?

The screensaver suite is a self-hosted version of the popular tool "Gyazo". It takes screenshots and stores them into an object store. This can be used to self-host screenshots to share with friends or collegues, and can easily be adapted to use a customer domain.

## screensaver

The screensaver client is a single-binary executable that can be customized to work on any platform, as the script relies on shelling the executables out to the operating system. Upon taking a photo and uploading it to `screenserver`, it will open the resulting link in a browser for previewing, as well as copy the link to your clipboard.

Variables:
| Variable        | Env Variable               | Default   | Description |
| -               |-                           |-          |-            |
| screenshot_cmd  |SCREENSAVER_SCREENSHOT_CMD  |`import`   |Screenshot taking executable. Must be able to save to a file as part of the executable with `screenshot_opts`|
| screenshot_opts |SCREENSAVER_SCREENSHOT_OPTS |`""`       |Options to add to `screenshot_cmd`|
| browser_cmd     |SCREENSAVER_BROWSER_CMD     |`xdg-open` |Browser command. The generated link will be appended to this command|
| api_token       |SCREENSAVER_X_API_TOKEN     |`""`       |The API Token for `screenserver` |
| server_url      |SCREENSAVER_SERVER_URL      |``         |screenserver Server URL|


## screenserver

The screenserver is the server component. It intakes a POST request (via AWS API Gateway and lambda) decodes the body, and writes it as a file into Amazon S3 or other S3-Compatible server. It will return an endpoint of the images link in conjunction with BASE_URL.

Variables:
| Variable        | Env Variable | Default   | Description |
| -               |-             |-          |-            |
|token            |TOKEN         |`""`       |The API Token for `screensaver`|
|s3_bucket        |S3_BUCKET     |`""`       |S3 bucket to store images in. They will be placed into a `/images` of the chosen s3 bucket and path.|
|base_url         |BASE_URL      |`""`       |Base URL for link generation.|