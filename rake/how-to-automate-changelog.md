# Script for tag-bound changelogs

## Why?

Who likes changelogs by hand?
The only thing is, you have to force everyone to write meaningful commit messages (the horror)

## How? 

```ruby
class Changelog < Rake::TaskLib
  include Rake::DSL if defined?(Rake::DSL) # back-compat

  def install
    desc "adds entries to CHANGELOG.md"
    task :changelog do
      sh "echo '\n\n# #{version_tag}\n\n' >> CHANGELOG.md"
      sh "git log --pretty='format:* %H %s' #{previous_tag}..#{version_tag} >> CHANGELOG.md"
    end
  end 

  private

  def version_tag
    "v#{version}"
  end

  def previous_tag
     prev_tag = nil
     # goes at tag list, pairs them all, until finding one which is the left pair of current tag
     `git tag -l`.lines.map(&:chomp).map(&:strip).sort do |v1, v2|
       prev1 = v1.split(".").map { |v| v.gsub(/[^\d]/, '') }.map(&:to_i)
       prev2 = v2.split(".").map {|v| v.gsub(/[^\d]/, '') }.map(&:to_i)
       prev1 <=> prev2
     end.each_cons(2) do |prev, current|
       next unless current.eql?(version_tag)
       prev_tag = prev
     end

     # if none was found, check last commit
     if prev_tag.nil?
       prev_tag = `git rev-list HEAD | tail -n 1`.chomp.strip
     end
     prev_tag
  end 
  
  def version
    gemspecs.first.version.to_s # see the other how to for multi gemspecs
  end
end
