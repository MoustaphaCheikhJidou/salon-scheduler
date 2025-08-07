#!/bin/bash
# Salon Appointment Scheduler – version minimaliste 100 % FCC-compliant

PSQL='psql -X -A -t --username=freecodecamp --dbname=salon -c'

MAIN_MENU() {
  echo -e "\n~~~~~ My Salon ~~~~~\n"
  echo "Welcome to My Salon, how can I help you?"
  echo "$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")" |
while IFS='|' read ID NAME; do
  echo "$ID) $NAME"
done
  # affiche toujours la liste immédiatement
  local SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS='|' read ID NAME; do
    echo "$ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  # id valide ?
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]; then
    MAIN_MENU         # relance le menu
    return
  fi

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
  exit 0                       # ← indispensable pour que le test-runner termine
}

MAIN_MENU
