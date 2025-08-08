#!/bin/bash
# Salon Appointment Scheduler – freeCodeCamp

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~"

print_services () {
  echo -e "\nWelcome to My Salon, how can I help you?"
  $PSQL "SELECT service_id,name FROM services ORDER BY service_id" |
  while IFS="|" read ID NAME; do
    echo "$ID) $NAME"
  done
}

ask_service () {
  read SERVICE_ID_SELECTED
  [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] &&
    { echo -e "\nThat is not a valid service number."; print_services; ask_service; return; }

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  [[ -z $SERVICE_NAME ]] &&
    { echo -e "\nI could not find that service."; print_services; ask_service; return; }
}

print_services
ask_service

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')" >/dev/null
fi
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

$PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')" >/dev/null
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
