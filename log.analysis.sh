total_requests=$(wc -l < "$LOG_FILE")
get_requests=$(grep -c '"GET ' "$LOG_FILE")
post_requests=$(grep -c '"POST ' "$LOG_FILE")

echo "Total Requests: $total_requests"
echo "GET Requests: $get_requests"
echo "POST Requests: $post_requests"

unique_ips=$(cut -d' ' -f1 "$LOG_FILE" | sort | uniq)
unique_ip_count=$(echo "$unique_ips" | wc -l)
echo "Unique IPs: $unique_ip_count"

echo "Requests by IP:"
for ip in $unique_ips; do
  get_by_ip=$(grep "^$ip " "$LOG_FILE" | grep -c '"GET ')
  post_by_ip=$(grep "^$ip " "$LOG_FILE" | grep -c '"POST ')
  echo "$ip - GET: $get_by_ip, POST: $post_by_ip"
done

failures=$(grep -E '" (4|5)[0-9]{2} ' "$LOG_FILE" | wc -l)
fail_percentage=$(awk "BEGIN {printf \"%.2f\", ($failures/$total_requests)*100}")

echo "Failed Requests (4xx/5xx): $failures"
echo "Failure Percentage: $fail_percentage%"

top_ip=$(cut -d' ' -f1 "$LOG_FILE" | sort | uniq -c | sort -nr | head -1)
echo "Top Active IP: $top_ip"

days=$(awk '{print $4}' "$LOG_FILE" | cut -d: -f1 | sed 's/\[//' | sort | uniq)
day_count=$(echo "$days" | wc -l)
avg_per_day=$(awk "BEGIN {printf \"%.2f\", ($total_requests/$day_count)}")
echo "Average Requests per Day: $avg_per_day"

echo "Days with Highest Failures:"
grep -E '" (4|5)[0-9]{2} ' "$LOG_FILE" | \
awk '{print $4}' | cut -d: -f1 | sed 's/\[//' | sort | uniq -c | sort -nr | head


echo "Requests Per Hour:"
awk -F: '{print $2}' "$LOG_FILE" | sort | uniq -c

echo "Status Code Breakdown:"
awk '{print $9}' "$LOG_FILE" | sort | grep -E '^[0-9]{3}$' | uniq -c | sort -nr

echo "Top GET Request IP:"
grep '"GET ' "$LOG_FILE" | cut -d' ' -f1 | sort | uniq -c | sort -nr | head -1
echo "Top POST Request IP:"
grep '"POST ' "$LOG_FILE" | cut -d' ' -f1 | sort | uniq -c | sort -nr | head -1

echo "Failure Requests by Hour:"
grep -E '" (4|5)[0-9]{2} ' "$LOG_FILE" | \
awk -F: '{print $2}' | sort | uniq -c | sort -nr
