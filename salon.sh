#!/bin/bash
PSQL='psql --username=freecodecamp --dbname=salon -t --no-align -c'

TO_MENU() {
  if [[ ! -z $1 ]]
  then 
    echo $1
  else
    echo -e '\nWelcome to Salon AWDJNASD.'
  fi

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  OPTIONS=()
  for CHOICE in ${SERVICES[@]}
  do
    IFS="|" read ID NAME <<< $CHOICE
    OPTIONS[$ID]=$NAME
    echo "$ID) $NAME"
  done

  echo -e 'Please select from one of the services listed above.'
  read SERVICE_ID_SELECTED
  if [[ -z ${OPTIONS[$SERVICE_ID_SELECTED]} ]]
  then
    TO_MENU "Please select a valid service number."
  else
    echo "Please enter your phone number."
    read CUSTOMER_PHONE
    
    CUSTOMER_INFO=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_INFO ]]
    then
      echo "No account found. Registering new customer..."
      echo "Please enter your name."
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" | echo -e '...'
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      IFS='|' read CUSTOMER_ID CUSTOMER_NAME <<< $CUSTOMER_INFO
    fi

    echo "Greetings, $CUSTOMER_NAME."
    echo "When would you like your appointment?"
    read SERVICE_TIME

    echo "I have put you down for a ${OPTIONS[$SERVICE_ID_SELECTED]} at $SERVICE_TIME, $CUSTOMER_NAME." <<< $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  fi
}

TO_MENU
