for _p in /usr/bin/perl /usr/local/bin/perl; do
  [ -x "$_p" ] && "$_p" -I. -Mzzz -e1 >/dev/null 2>&1 && break
done
