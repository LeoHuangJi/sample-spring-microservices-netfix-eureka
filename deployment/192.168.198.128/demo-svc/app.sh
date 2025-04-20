#!/bin/sh
SERVICE_NAME=demo-service
PATH_TO_JAR=/opt/app/demo-svc/lib/simple-app-0.0.1-SNAPSHOT.jar
LOG_DIR=/opt/app/demo-svc/logs/log.txt
PID_PATH_NAME=/opt/app/demo-svc/application-pid
PROFILE=${2:-default}  # N?u không truy?n profile thì m?c d?nh là "default"

# Ki?m tra Java dã cài chua
if ! java -version > /dev/null 2>&1; then
    echo "Java is not installed or not in PATH!"
    exit 1
fi

# Ki?m tra JAR có t?n t?i không
if [ ! -f "$PATH_TO_JAR" ]; then
    echo "Error: JAR file not found at $PATH_TO_JAR"
    exit 1
fi

case $1 in
    start)
        echo "Starting $SERVICE_NAME with profile [$PROFILE]..."
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME)
            if ps -p $PID > /dev/null 2>&1; then
                echo "$SERVICE_NAME is already running (PID $PID)"
                exit 0
            else
                echo "Stale PID file found. Removing."
                rm $PID_PATH_NAME
            fi
        fi

        # Log rotation don gi?n
        if [ -f "$LOG_DIR" ] && [ $(du -m "$LOG_DIR" | cut -f1) -gt 100 ]; then
            mv $LOG_DIR "$LOG_DIR.$(date +%Y%m%d%H%M%S)"
            echo "Log rotated."
        fi

        nohup java -Dspring.profiles.active=$PROFILE -jar $PATH_TO_JAR >> $LOG_DIR 2>&1 &
        echo $! > $PID_PATH_NAME

        sleep 3  # Ð?i ?ng d?ng kh?i d?ng

        if ps -p $(cat $PID_PATH_NAME) > /dev/null 2>&1; then
            echo "$SERVICE_NAME started successfully with PID $(cat $PID_PATH_NAME)"
        else
            echo "Error: $SERVICE_NAME failed to start. Check logs below:"
            tail -n 20 $LOG_DIR
            rm $PID_PATH_NAME
            exit 1
        fi
    ;;
    stop)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME)
            echo "Stopping $SERVICE_NAME (PID $PID)..."
            kill $PID
            rm $PID_PATH_NAME
            echo "$SERVICE_NAME stopped."
        else
            echo "$SERVICE_NAME is not running."
        fi
    ;;
    restart)
        $0 stop
        sleep 2
        $0 start $PROFILE
    ;;
    status)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME)
            if ps -p $PID > /dev/null 2>&1; then
                echo "$SERVICE_NAME is running (PID $PID)"
            else
                echo "$SERVICE_NAME PID file exists but process not running."
            fi
        else
            echo "$SERVICE_NAME is not running."
        fi
    ;;
    console)
        echo "Running $SERVICE_NAME in console mode with profile [$PROFILE]..."
        java -Dspring.profiles.active=$PROFILE -jar $PATH_TO_JAR
    ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|console} [profile]"
        exit 1
    ;;
esac
