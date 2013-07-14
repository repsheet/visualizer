class Backend
  def self.summary(connection)
    if connection.exists("offenders")
      suspects, blacklisted = optimized(connection)
    else
      suspects, blacklisted = standard(connection)
    end

    [suspects.sort_by{|k,v| -v[:total]}.take(10), blacklisted]
  end

  def self.breakdown(connection)
    data = {}
    offenders = connection.keys("*:repsheet").map {|o| o.split(":").first}
    offenders.each do |offender|
      data[offender] = {"totals" => {}}
      connection.smembers("#{offender}:detected").each do |rule|
        data[offender]["totals"][rule] = connection.get "#{offender}:#{rule}:count"
      end
    end
    aggregate = Hash.new 0
    data.each {|ip,data| data["totals"].each {|rule,count| aggregate[rule] += count.to_i}}
    [data, aggregate]
  end

  def self.activity(connection)
    connection.lrange("#{@ip}:requests", 0, -1)
  end

  def self.worldview(connection, database)
    data = {}
    offenders = connection.keys("*:repsheet*").map {|o| o.split(":").first}
    offenders.each do |address|
      details = database.country(address)
      next if details.nil?
      data[address] = [details.latitude, details.longitude]
    end
    data
  end

  private

  def self.optimized(connection)
    suspects = {}
    connection.zrevrangebyscore("offenders", "+inf", "0").each do |actor|
      next if connection.get("#{actor}:repsheet:blacklist") == "true"
      suspects[actor] = Hash.new 0
      suspects[actor][:detected] = connection.smembers("#{actor}:detected").join(", ")
      suspects[actor][:total] = connection.zscore("offenders", actor).to_i
    end

    [suspects, blacklist(connection)]
  end

  def self.standard(connection)
    suspects = {}

    connection.keys("*:requests").map {|d| d.split(":").first}.reject {|ip| ip.empty?}.each do |actor|
      detected = connection.smembers("#{actor}:detected").join(", ")
      blacklist = connection.get("#{actor}:repsheet:blacklist")

      if !detected.empty? && blacklist != "true"
        suspects[actor] = Hash.new 0
        suspects[actor][:detected] = detected
        connection.smembers("#{actor}:detected").each do |rule|
          suspects[actor][:total] += connection.get("#{actor}:#{rule}:count").to_i
        end
      end
    end

    [suspects, blacklist(connection)]
  end

  def self.blacklist(connection)
    blacklisted = {}
    connection.keys("*:*:blacklist").map {|d| d.split(":").first}.reject {|ip| ip.empty?}.each do |actor|
      next unless connection.get("#{actor}:repsheet:blacklist") == "true"

      blacklisted[actor] = Hash.new 0
      blacklisted[actor][:detected] = connection.smembers("#{actor}:detected").join(", ")
      connection.smembers("#{actor}:detected").each do |rule|
        blacklisted[actor][:total] += connection.get("#{actor}:#{rule}:count").to_i
      end
    end
    blacklisted
  end
end
