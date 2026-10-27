#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

while true
do
  SERVICES=$(psql -U freecodecamp -d salon -At -c "select service_id,name from services order by service_id;")
  echo "$SERVICES" | while IFS='|' read -r id name
  do
    echo "$id) $name"
  done

  read SERVICE_ID_SELECTED

  SERVICE_NAME=$(psql -U freecodecamp -d salon -At -c "select name from services where service_id=$SERVICE_ID_SELECTED;")
  SERVICE_NAME=$(echo $SERVICE_NAME | xargs)

  if [[ -z $SERVICE_NAME ]]
  then
      echo -e "\nI could not find that service. What would you like today?"
  else
    break
  fi
  done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER=$(psql -U freecodecamp -d salon -At -c "select customer_id,name from customers where phone='$CUSTOMER_PHONE'")
CUSTOMER_ID=$(echo $CUSTOMER | cut -d'|' -f1)
CUSTOMER_NAME=$(echo $CUSTOMER | cut -d'|' -f2)

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  psql -U freecodecamp -d salon -c "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME');" > /dev/null
  CUSTOMER_ID=$(psql -U freecodecamp -d salon -At -c "select customer_id from customers where phone='$CUSTOMER_PHONE';" | xargs)

fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

psql -U freecodecamp -d salon -c "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" > /dev/null

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."