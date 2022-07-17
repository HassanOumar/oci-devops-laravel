#!/usr/bin/env bash

set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

echo "Caching configuration..."
# (cd /var/www/html && php artisan config:cache && php artisan view:cache && php artisan event:cache && php artisan storage:link)

if [ "$role" = "app" ]; then

    echo "Running the server..."
    exec apache2-foreground

elif [ "$role" = "queue" ]; then

    echo "Running the queue..."
    php /var/www/html/artisan queue:work

elif [ "$role" = "scheduler" ]; then

    echo "Running the scheduler..."
    while [ true ]
    do
      php /var/www/html/artisan schedule:run --verbose --no-interaction &
      sleep 60
    done

elif [ "$role" = "websocket" ]; then

    echo "Running the websocket server..."
    php /var/www/html/artisan websocket:serve

else
    echo "Could not match the container role \"$role\""
    exit 1
fi
