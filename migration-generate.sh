dev_or_not=$1
if [[ $dev_or_not =~ "dev-migration" ]]
then
	filename=$(echo dev-migration-`date +%s`-dev-migration  | sed -re"s#[ ]+#-#g" | sed -e"s#[^a-zA-Z0-9-]##g" | tr [A-Z] [a-z])
else
	filename=$(echo `date +%s` $* | sed -re"s#[ ]+#-#g" | sed -e"s#[^a-zA-Z0-9-]##g" | tr [A-Z] [a-z])
fi
echo $filename
basedir=$(dirname $0)

full_file_path=$(echo "$basedir/migrations/$filename.sql")
touch $full_file_path
echo $full_file_path has been created. Please edit the same and check in to complete adding the sql migration

