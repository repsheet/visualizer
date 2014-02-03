class Backend
  def self.blacklist_total(connection)
    connection.smembers("repsheet:blacklist:history").size
  end

  def self.whitelisted?(connection, ip)
    connection.exists("#{ip}:repsheet:whitelist")
  end

  def self.blacklisted?(connection, ip)
    connection.exists("#{ip}:repsheet:blacklist")
  end

  def self.ofdp_score(connection, ip)
    connection.get("#{ip}:score")
  end

  def self.summary(connection)
    if connection.exists("offenders")
      suspects, blacklisted = optimized(connection)
    else
      suspects, blacklisted = standard(connection)
    end

    [suspects.sort_by{|k,v| -v[:total]}.take(10), blacklisted]
  end

  def self.suspects(connection)
    if connection.exists("offenders")
      suspects = optimized(connection)
    else
      suspects = standard(connection)
    end
  end

  def self.breakdown(connection)
    data = Hash.new(0)
    offenders = connection.keys("*:repsheet").map {|o| o.split(":").first}
    offenders.each do |offender|
      connection.zrange("#{offender}:detected", 0, -1).each do |rule|
        data[rule] += connection.zscore("#{offender}:detected", rule).to_i
      end
    end
    data.take(10)
  end

  def self.activity(connection, actor)
    connection.lrange("#{actor}:requests", 0, -1)
  end

  def self.worldview(connection, database)
    data = {}
    offenders = connection.keys("*:repsheet:blacklist").map {|o| o.split(":").first}
    offenders.each do |address|
      details = database.country(address)
      next if details.nil?
      data[address] = [details.latitude, details.longitude]
    end
    data
  end

  private

  def self.triggered_rules(connection, actor)
    connection.zrange("#{actor}:detected", 0, -1)
  end

  def self.optimized(connection)
    suspects = {}

    connection.zrevrangebyscore("offenders", "+inf", "0").each do |actor|
      next if connection.get("#{actor}:repsheet:blacklist") == "true"
      suspects[actor] = Hash.new 0
      suspects[actor][:detected] = triggered_rules(connection, actor).join(", ")
      suspects[actor][:total] = score_actor(connection, actor, nil, true)
      suspects[actor][:requests] = connection.llen("#{actor}:requests")
    end

    [suspects, blacklist(connection)]
  end

  def self.standard(connection)
    suspects = {}

    connection.keys("*:requests").map {|d| d.split(":").first}.reject {|ip| ip.empty?}.each do |actor|
      detected = triggered_rules(connection, actor)
      blacklist = connection.get("#{actor}:repsheet:blacklist")

      if !detected.empty? && blacklist != "true"
        suspects[actor] = Hash.new 0
        suspects[actor][:detected] = detected.join(", ")
        suspects[actor][:total] = score_actor(connection, actor, detected)
        suspects[actor][:requests] = connection.llen("#{actor}:requests")
      end
    end

    [suspects, blacklist(connection)]
  end

  def self.blacklist(connection, optimized=false)
    blacklisted = {}

    connection.keys("*:*:blacklist").map {|d| d.split(":").first}.reject {|ip| ip.empty?}.each do |actor|
      next unless connection.get("#{actor}:repsheet:blacklist") == "true"
      detected = triggered_rules(connection, actor)
      blacklisted[actor] = Hash.new 0
      blacklisted[actor][:detected] = detected.join(", ")
      blacklisted[actor][:total] = score_actor(connection, actor, detected, optimized)
      blacklisted[actor][:requests] = connection.llen("#{actor}:requests")
    end

    blacklisted
  end

  def self.whitelist(connection)
    connection.keys("*:*:whitelist").map {|record| record.split(":").first}.reject {|ip| ip.empty?}
  end

  def self.score_actor(connection, actor, detected, optimized=false)
    return connection.zscore("offenders", "#{actor}").to_i if optimized

    detected.reduce(0) do |memo, rule|
      memo += connection.zscore("#{actor}:detected", rule).to_i
    end
  end
end
