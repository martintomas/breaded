import * as Sentry from "@sentry/browser";

if(process.env.NODE_ENV === 'production') {
    Sentry.init({
        dsn: process.env.SENTRY_DSN_FE,
        environment: process.env.NODE_ENV
    });
}
