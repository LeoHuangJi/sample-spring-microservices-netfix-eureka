#!/bin/sh
SERVICE_NAME=discovery-service
PATH_TO_JAR=/opt/app/discovery-svc/lib/discovery-service-1.1-SNAPSHOT.jar
LOG_DIR=/opt/app/discovery-svc/logs/app.log
MAX_SIZE=10485760  # 10MB (bytes)
PID_PATH_NAME=/opt/app/discovery-svc/application-pid

# Set JAVA_HOME rõ ràng t?i dây — ví d? Java 22:
JAVA_HOME=/usr/lib/jvm/jdk-22+36
JAVA_CMD=$JAVA_HOME/bin/java

PROFILE=${2:-profile}         # Tham so 2: profile, mac dinh "profile"
LOGGING_FILE_SHELL=${3:-on}              # Tham so 3: bat/tat log, mac dinh "on"

if [ ! -x "$JAVA_CMD" ]; then
    echo "Error: Java not found at $JAVA_CMD"
    exit 1
fi

if [ ! -f "$PATH_TO_JAR" ]; then
    echo "Error: JAR file not found at $PATH_TO_JAR"
    exit 1
fi

case $1 in
    start)
        echo "Starting $SERVICE_NAME..."
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

        if [ "$LOGGING_FILE_SHELL" = "on" ]; then
            if [ -f "$LOG_DIR" ] && [ $(stat -c%s "$LOG_DIR") -ge $MAX_SIZE ]; then
                mv "$LOG_DIR" "$LOG_DIR.$(date +%Y%m%d%H%M%S)"
                echo "[$(date)] Log rotated."
            fi
            echo "File shell logging is enabled. Output -> $LOG_DIR"
            nohup $JAVA_CMD -jar $PATH_TO_JAR >> $LOG_DIR 2>&1 &
        else
            echo "File shell logging is disabled. Output will not be saved."
            nohup $JAVA_CMD -jar $PATH_TO_JAR >/dev/null 2>&1 &
        fi

        echo $! > $PID_PATH_NAME
        sleep 3

        if ps -p $(cat $PID_PATH_NAME) > /dev/null 2>&1; then
            echo "$SERVICE_NAME started successfully with PID $(cat $PID_PATH_NAME)"
        else
            echo "Error: $SERVICE_NAME failed to start."
            [ "$LOGGING_FILE_SHELL" = "on" ] && tail -n 20 $LOG_DIR
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
        $0 start "$PROFILE" "$LOGGING_FILE_SHELL"
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
        echo "Running $SERVICE_NAME in console..."
        $JAVA_CMD -jar $PATH_TO_JAR
    ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|console} [profile] [on|off]"
        exit 1
    ;;
esac


