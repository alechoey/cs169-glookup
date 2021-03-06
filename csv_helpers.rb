require 'csv'

class DowncaseHash < Hash
  def has_key?(key)
    super(key.downcase)
  end

  def [](key)
    super(key.downcase) unless key.nil?
  end

  def []=(key, val)
    super(key.downcase, val) unless key.nil? || val.nil?
  end
end

class NameHash < DowncaseHash
  def []=(key, val)
    super(key, val)
    names = remove_middle_name(key)
    names.each do |name|
      super(name, val) unless has_key? name
    end
  end

private
  def remove_middle_name(name)
    names = []
    return names if name.nil?
    words = name.split(/\s/)
    if words.count > 2
      (0..words.count-2).each do |i|
        (i+2..words.count-1).each do |j|
          names << (words[0..i] + words[j..words.count-1]).join(' ')
        end
      end
    end
    names
  end
end


class CSV
  def self.load_hash(csv_file, key="", values=[], options={})
    target = options[:target] || DowncaseHash.new
    value_type = options[:value_type] || values.class
    CSV.foreach(csv_file, :headers => true, :return_headers => false) do |row|
      value_type = value_type.to_s
      case value_type
      when 'Array'
        vals = values.map { |val| row[val] }
      when 'Hash'
        vals = {}
        values.each do |val|
          vals[val] = row[val]
        end
      else
        vals = row[values]
      end
      target[row[key]] = vals
    end
    target
  end

  def self.dump_array(csv_file, arr_of_objs, header=[])
    CSV.open(csv_file, 'wb') do |csv|
      csv << header unless header.empty?
      arr_of_objs.each do |obj|
        csv << obj
      end
    end
  end
end
