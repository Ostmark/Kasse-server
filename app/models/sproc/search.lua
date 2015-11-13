domain = ARGV[1]
prefix = ARGV[2]
max    = ARGV[3]
types  = ARGV[4]

redis.call ("LRANGE", [[search:]] .. domain .. [[:]] .. prefix, 0, max)

