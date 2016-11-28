# encoding: UTF-8

# コマンド群
module Cmd
	class << self
		def sync input
			commands_base("sync", "s", input, [])
		end
		def delete_branch input, target
			commands_base("branch -D", "d", input, [target])
		end
		def merge input, target
			commands_base("merge", "m", input, [target])
		end
		def merge_ff input, target
			commands_base("merge --ff", "mf", input, [target])
		end
		def checkout input, target
			commands_base("checkout", "c", input, [target])
		end
		
		private
		def commands_base name, abbreviation_command, input, target
			abbcommand_length = abbreviation_command.length
			if input.take(abbcommand_length).join("")==abbreviation_command
				input.shift(abbcommand_length)
				exec_command(name, target)
				return true
			end
			return false
		end
		def exec_command name, argument
			abort "#{name}の引数がありません。" if argument.include?(nil)
			# Array#shiftなどは、要素が無いときはnilを返すのでそれを見つける
			exe_shell = "git #{name} #{argument.map{|a| %!"#{a}"! }.join(" ")}"
			puts exe_shell
			puts `#{exe_shell}\n`
			return_num = $?.to_i
			abort "#{name}に失敗しました。" unless return_num==0
		end
	end
end

def current_branch
	`git rev-parse --abbrev-ref HEAD`.chomp
end

# この関数群を動き回って処理していく
def start input, target
	case input[0]
	when "c"
		checkouts(input, target)
	when "m"
		merges(input, target)
	when "s"
		Cmd.sync(input)
	when "d"
		Cmd.delete_branch(input, target.shift)
	else
		abort "コマンドが不明です'#{input.join}'"
	end
	if input.length>0
		start(input, target)
	end
end
def checkouts input, target
	start_branch = current_branch
	
	Cmd.checkout(input, target.shift)
	Cmd.merge_ff(input, start_branch)
	Cmd.merge(input, start_branch)
	is_deleted = Cmd.delete_branch(input, start_branch)
	Cmd.sync input
	Cmd.checkout(input, start_branch) unless is_deleted
end
def merges input, target
	merge_target = target.shift
	
	Cmd.merge_ff(input, merge_target)
	Cmd.merge(input, merge_target)
	Cmd.delete_branch(input, merge_target)
end

# 起動用
input = ARGV.shift.split("")
start(input, ARGV)
puts("処理が終了した際に引数が残っています'#{ARGV}'") unless ARGV.empty?
