#!/bin/sh

if [ "$(whoami)" != 'root' ]
then
  echo "You need root permission to run the installation script"
  exit 1
fi

book_user="book-node"

book_node_path="/usr/local/bin/book-node"
book_motd_path="/usr/local/bin/book-motd"

book_files_path="/var/lib/book-node/"
book_file_booking="${book_files_path}bookings"
book_file_mails="${book_files_path}mails"

cp ./book-node{.am,}
cp ./book-motd{.am,}

sed -i "s,@BOOKING_FILE_PATH@,$book_file_booking,g" ./book-node
sed -i "s,@MAIL_FILE_PATH@,$book_file_mails,g" ./book-node
sed -i "s,@BOOKING_FILE_PATH@,$book_file_booking,g" ./book-motd
sed -i "s,@MAIL_FILE_PATH@,$book_file_mails,g" ./book-motd

# we do not want book-motd appears in autocomplete
chmod -x book-motd

cp ./book-node $book_node_path
cp ./book-motd $book_motd_path

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
if [ -r $book_motd_path ] && which perl > /dev/null
then
  perl $book_motd_path
fi
EOF
  echo "  /etc/profile.d/book-motd.sh startup script created"
else
  if ! grep "^[^#].*perl $book_motd_path" /etc/profile > /dev/null
  then
    cat >> /etc/profile << EOF
# book-node prompt at startup
if [ -r $book_motd_path ] && which perl > /dev/null
then
  perl $book_motd_path
fi
EOF
    echo "  Script call added in /etc/profile"
  else
    echo "  Script already exists in /etc/profile"
  fi
fi


chown $book_user:$book_user $book_node_path
chmod u+s $book_node_path

echo "Set suid to $book_node_path"

mkdir -p $book_files_path
touch $book_file_booking
touch $book_file_mails

chown $book_user:$book_user $book_files_path
chown $book_user:$book_user $book_file_booking
chown $book_user:$book_user $book_file_mails

echo "Create $book_files_path files"
