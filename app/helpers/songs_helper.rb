module SongsHelper
  def breadcrumb_paths(dir)
    dirnames = dir.split(%r{/})
    dirnames.map.with_index{|dirname, i|
      path = dirnames[0, i+1].join('/')
      [dirname, path]
    }
  end
end
