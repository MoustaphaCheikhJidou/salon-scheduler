#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~"
  echo -e "\n1) Book an appointment\n2) Exit"
  read MAIN_CHOICE
  case $MAIN_CHOICE in
    1) BOOK ;;
    2) echo Goodbye ;;
    *) MAIN_MENU ;;
  esac
}

BOOK() {
  echo -e "\nThese are the services we offer:"
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    BOOK
    return
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]; then
    BOOK
    return
  fi
  echo -e "\nWhat's your phone number?"
  read PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$PHONE'")
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(phone,name) VALUES('$PHONE','$CUSTOMER_NAME')"
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$PHONE'")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  $PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')"
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
#!/bin/bash
echo "Hello Salon"
