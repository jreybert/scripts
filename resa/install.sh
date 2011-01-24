#!/bin/sh

if [ "$(whoami)" != 'root' ]
then
  echo you are using a non-privileged account
  exit 1
fi

book_user="book-node"
book_path="book-node"

# we do not want book-motd appears in autocomplete
chmod -x book-motd

cp book-node book-motd /usr/local/bin/

if ! grep "^$book_user" /etc/passwd > /dev/null
then
#if [[ $user_exists ne 1 ]]; then
# create book-node user and group
  useradd -s /bin/false -MU $book_user
  echo "User book-node created"
else
  echo "User book-node already exists"
fi

echo "book-motd startup script installation:"
# if /etc/profile provides profile.d behavior
if grep "^[^#].*/etc/profile" /etc/profile > /dev/null && [ -d /etc/profile.d ]
then
  cat > /etc/profile.d/book-motd.sh << EOF
# book-node prompt at startup
if [ -r /usr/local/bin/book-motd ] && which perl > /dev/null
then
  perl /usr/local/bin/book-motd
fi
EOF
  echo "  /etc/profile.d/book-motd.sh startup script created"
else
  if ! grep "^[^#].*perl /usr/local/bin/book-motd" /etc/profile > /dev/null
  then
    cat >> /etc/profile << EOF
# book-node prompt at startup
if [ -r /usr/local/bin/book-motd ] && which perl > /dev/null
then
  perl /usr/local/bin/book-motd
fi
EOF
    echo "  Script call added in /etc/profile"
  else
    echo "  Script already exists in /etc/profile"
  fi
fi


chown $book_user:$book_user /usr/local/bin/book-node
chmod u+s /usr/local/bin/book-node

echo "Set suid to /usr/local/bin/book-node"

mkdir -p /var/lib/book-node/
touch /var/lib/book-node/bookings 
touch /var/lib/book-node/mails

chown $book_user:$book_user /var/lib/book-node/ 
chown $book_user:$book_user /var/lib/book-node/bookings 
chown $book_user:$book_user /var/lib/book-node/mails 

echo "Create /var/lib/book-node/ files"
