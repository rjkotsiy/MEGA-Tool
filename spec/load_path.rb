# add global path to global scope
lp = File.join(Dir.pwd, 'lib', 'components')
$LOAD_PATH.unshift(lp) unless $LOAD_PATH.include?(lp)