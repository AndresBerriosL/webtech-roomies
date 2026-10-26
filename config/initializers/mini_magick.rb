
# Windows: force MiniMagick to use ImageMagick 7.
# Avoid Windows' built-in convert.exe.
MiniMagick.configure do |config|
  config.cli_prefix = nil
end

MiniMagick.instance_variable_set(:@imagemagick7, true)
