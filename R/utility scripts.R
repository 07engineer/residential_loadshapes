#create empty folders for each climate zone
walk(1:12, function(x) dir.create(str_c("FCZ", x)))

