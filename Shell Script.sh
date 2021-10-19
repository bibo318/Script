 Shell Script To List All Top Hitting IP Address to your webserver.
# where to store final report?
DEST=/var/www/reports/ips
 
# domain name
DOM=$1
 
# log file location
LOGFILE=/var/logs/httpd/$DOM/access.log
 
# die if no domain name given 
[ $# -eq 0 ] && exit 1
 
# make dir 
[ ! -d $DEST ] && mkdir -p $DEST
 
# ok, go though log file and create report 
if [ -f $LOGFILE ]
then
 echo "Processing log for $DOM..."
 awk '{ print $1}' $LOGFILE | sort  | uniq -c  | sort -nr > $DEST/$DOM.txt
 echo "Report written to $DEST/$DOM.txt"
fi