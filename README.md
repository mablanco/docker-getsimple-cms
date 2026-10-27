# docker-getsimple-cms

Docker image for GetSimple CMS, an XML based, stand-alone, fully independent and lite Content Management System. It ships [GetSimple CMS CE](https://github.com/GetSimpleCMS-CE/GetSimpleCMS-CE) (Community Edition), the maintained fork of the original project (<http://get-simple.info/>), whose last release was 3.3.16 in 2020.

This image sets up a **development** environment and relies on Debian Linux, Apache 2 and PHP 8 (with `php.ini-development`, so errors are displayed). It should **NEVER** be used in production.

## How to use this image

This will start a GetSimple CMS instance listening on port 80:

```bash
~ docker run -d -p 80:80 --name getsimple mablanco/getsimple-cms
```

If you'd like persistance, you can create a volume for that purpose:

```bash
~ docker volume create getsimple_web
~ docker run -d -p 80:80 --name getsimple -v getsimple_web:/var/www/html mablanco/getsimple-cms
```

Once the container is running for the first time, navigate to `/admin` to be redirected to the upgrade and install scripts. The container has no mail server, so the installer will report that it could not email the registration details: write down the generated password it shows on screen.

## Upgrading from 3.3.16

Images up to `3.3.16-20250120` ship the original GetSimple CMS 3.3.16, which is affected by CVE-2025-48492 (remote code execution through component editing). If you have a persistent volume created with one of those images, back it up before switching to a newer tag, then follow the [GetSimple CMS CE upgrade notes](https://github.com/GetSimpleCMS-CE/GetSimpleCMS-CE#readme).

## Building the image

```bash
~ docker build -t mablanco/getsimple-cms .
```

The GetSimple CMS CE version is set with the `GETSIMPLE_VERSION` build argument, and the downloaded release is checked against `GETSIMPLE_SHA256`. Update both together.
