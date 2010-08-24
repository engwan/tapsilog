require 'echoe'

Echoe.new("tapsilog") do |p|
  p.author = "Palmade"
  p.project = "tapsilog"
  p.summary = "Hydrid app-level logger from Palmade. Analogger fork."

  p.dependencies = [ 'eventmachine' ]

  p.need_tar_gz = false
  p.need_tgz = true

  p.clean_pattern += [ "pkg", "lib/*.bundle", "*.gem", ".config" ]
  p.rdoc_pattern = [ 'README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc' ]
end
