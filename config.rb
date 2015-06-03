def frameworks_in_path(path)
  files = `ls #{path}`.split("\n")
  p files
  frameworks ||=[]
  files.each do |line|
    line =~ /(\w+).bridgesupport/
    next if $1.nil?
    frameworks << $1 unless frameworks.include?($1)
  end
end


def android_base_url
  '/Library/RubyMotion/data/android'
end

def default_android_version
  '17'
end

def android_frameworks(version)
  path = [android_base_url, version ,'BridgeSupport'].join('/')
  frameworks_in_path(path)
end
