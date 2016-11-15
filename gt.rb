# encoding: UTF-8

class Cmd
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
			end
		end
		def exec_command name, argument
			abort "#{name}の引数がありません。" if argument.include?(nil)
			# Array#shiftなどは、要素が無いときはnilを返すのでそれを見つける
			exe_shell = "git #{name} #{argument.map{|a| %!"#{a}"! }.join(" ")}"
			puts exe_shell
			puts `#{exe_shell}`
			return_num = $?.to_i
			abort "#{name}に失敗しました。" unless return_num==0
		end
	end
end

def current_branch
	`git rev-parse --abbrev-ref HEAD`.chomp
end

# ここからメイン処理

input = ARGV.shift.split("")

Cmd.sync(input)

if input[0]=="c"
	start_branch = current_branch
	
	Cmd.checkout(input, ARGV.shift)
	Cmd.merge_ff(input, start_branch)
	Cmd.merge(input, start_branch)
	Cmd.delete_branch(input, start_branch)
	Cmd.sync input
	Cmd.checkout(input, start_branch)
elsif input[0]=="m"
	merge_target = ARGV.shift
	
	Cmd.merge_ff(input, merge_target)
	Cmd.merge(input, merge_target)
	Cmd.delete_branch(input, merge_target)
elsif input[0]=="d"
	Cmd.delete_branch(input, ARGV.shift)
end

Cmd.sync input
