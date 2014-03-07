#!/bin/bash
basedir=$(dirname $0)
full_path=$(echo "$basedir/migrations/")

DBUSER=foo
DBPASSWORD=foo
DBHOST=foo
DB=foo

setup_mysql_params() {
	
	configFile=$basedir/../src/main/resources/weaverbirdconfig.yml

	DBUSER=`less $configFile | sed -n '/'$DOMAIN'\:/,//p' | awk '{$1=$1}{ print }' | grep -E '^RDBMSUser' | cut -d':' -f2 | awk '{$1=$1}{ print }' | less`
	DBPASSWORD=`less $configFile | sed -n '/'$DOMAIN'\:/,//p' | awk '{$1=$1}{ print }' | grep -E '^RDBMSPassword' | cut -d':' -f2 | awk '{$1=$1}{ print }' | less`
	DBHOST=`less $configFile | sed -n '/'$DOMAIN'\:/,//p' | awk '{$1=$1}{ print }' | grep -E '^RDBMSHost' | cut -d':' -f2 | awk '{$1=$1}{ print }' | less`
	DB=`less $configFile | sed -n '/'$DOMAIN'\:/,//p' | awk '{$1=$1}{ print }' | grep -E '^RDBMSDatabase' | cut -d':' -f2 | awk '{$1=$1}{ print }' | less`

	echo "RDBMSUser: $DBUSER"
	echo "RDBMSPassword: $DBPASSWORD"
	echo "RDBMSHost: $DBHOST"
	echo "RDBMSDatabase: $DB"
	if [ -d "/usr/lib/mysql-5.1.36-linux-x86_64-glibc23/bin" ] ; then
	  PATH="$PATH:/usr/lib/mysql-5.1.36-linux-x86_64-glibc23/bin/"
	fi
}

setup_migrations() {
	fire_sql "create table if not exists MIGRATIONS(file varchar(255), primary key(file))"
}

fire_sql() {
	mysql -u$DBUSER -p$DBPASSWORD -h$DBHOST $DB -e"$1"
}

apply_sql() {
	out=$(fire_sql "select * from MIGRATIONS where file='$1'")
	rows=$(echo $out | grep $1 | wc -l )
	if [[ rows -eq 0 ]]
	then
		echo "Applying File: $f"
		mysql --verbose -u$DBUSER -p$DBPASSWORD -h$DBHOST $DB < $1
		fire_sql "insert into MIGRATIONS(file) values ('$1')"
	else
		echo "Skipping $f - already applied"
	fi
}


setup_mysql_params
setup_migrations
pushd $full_path

ls -1 | sort | while read f
do
	if [[ $f = dev-migration-* ]]
	then
		if [[ $DOMAIN = development ]]
		then
				apply_sql $f	
		fi
	else
		apply_sql $f
	fi
done

popd
