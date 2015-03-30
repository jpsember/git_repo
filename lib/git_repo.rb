# Find git repository, branch info
#
require 'js_base'
req 'git_repo/git_parser'

class GitRepo

  attr_reader :basedir,:branch,:modified,:deleted,:untracked,:added,:unmerged,:renamed

  def past_commit_name(index = -1)
    raise Exception,"index must be negative" if index >= 0
    if !@past_commit_names
      x,_ = scall('git log --pretty=format:"%h" -10')
      x = x.split("\n").to_a
      @past_commit_names = x
    end
    @past_commit_names[-1 - index]
  end

  def abs_path(file)
    File.join(@basedir,file)
  end

  def find_repo(path)
    path = File.absolute_path(path)
    while true
      git_path = File.join(path,'.git')
      if File.directory?(git_path)
        return path
      end
      old_path = path
      path = File.dirname(path)
      raise Exception,"No .git found" if path == old_path
    end
    path
  end

  def initialize
    @past_commit_names = nil
    @basedir = find_repo(Dir.pwd)

    # We may be in detached head mode
    x,problem = scall("git symbolic-ref -q HEAD",false)
    if !problem
      x.chomp!
      @branch = File.basename(x)
    end
    build_status
  end

  # Perform a git status to determine modified, deleted, untracked, and added files
  #
  def build_status
    @modified = []
    @deleted = []
    @untracked = []
    @added = []
    @unmerged = []
    @renamed = []

    x,_ = scall('git status --porcelain')
    x.split("\n").each do |y|

      gp = GitParser.new(y)

      # The first two characters are the status
      status = gp.parse_chars(2)
      gp.parse(' ')
      path1 = gp.parse_path()
      path2 = nil
      if gp.read_if(' -> ')
        path2 = gp.parse_path()
      end

      # if path2
      #   raise Exception,"cannot process renamed files yet: '#{path2}'"
      # end

      case status
      when 'R '
        @renamed << [path1,path2]
      when 'RM'
        @renamed << [path1,path2]
        @modified << path2
      when 'RD'
        @renamed << [path1,path2]
        @deleted << path2
      when 'M '
        @modified << path1
      when ' M'
        @modified << path1
      when 'D '
        @deleted << path1
      when ' D'
        @deleted << path1
      when 'DD'
        @deleted << path1
      when 'DU'
        @deleted << path1
        @unmerged << path1
      when '??'
        @untracked << path1
      when 'AA'
        @added << path1
      when 'A '
        @added << path1
      when 'AM'
        @added << path1
        @modified << path1
      when 'AD'
        @added << path1
        @deleted << path1
      when 'MM'
        @modified << path1
      when 'UA'
        @unmerged << path1
        @added << path1
      when 'AU'
        @unmerged << path1
        @added << path1
      when 'UU'
        @unmerged << path1
      when 'MD'
        @modified << path1
        @unmerged << path1
      else
        unimp('use raw format so we can do diff ourselves')
        raise Exception,"unknown file state:'#{status}'"
      end
    end
  end

  def to_s
    "GitRepo basedir='#@basedir' branch='#@branch' m:#{@modified.size} d:#{@deleted.size} ?:#{@untracked.size} u:#{@unmerged.size}"
  end


end
