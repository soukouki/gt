# encoding: UTF-8

# これつけないと動かないけど、出来るだけメイン部分とは離したい
# それぞれの環境に適当に合わせてください
def command cmd
	`powershell #{cmd}`
end

# コマンド群
module Cmd extend self
	# 処理の流れにコマンドと省略コマンドを入れる
	def sync input
		commands_base("sync", "s", input, [])
	end
	def delete_branch input, target
		commands_base("branch -D", "d", input, [target])
	end
	def merge input, target
		commands_base("merge --no-ff", "m", input, [target])
	end
	def merge_ff input, target
		commands_base("merge --ff", "mf", input, [target])
	end
	def merge_squash input, target
		commands_base("merge --squash", "ms", input, [target])
	end
	def checkout input, target
		commands_base("checkout", "c", input, [target])
	end
	def new_branch input, target
		commands_base("checkout -b", input, [])
	end
	
	private
	# ちょっとよくわかんない
	def commands_base name, abbreviation_command, input, target
		abbcommand_length = abbreviation_command.length
		if input.take(abbcommand_length).join("")==abbreviation_command
			input.shift(abbcommand_length)
			exec_command(name, target)
			return true
		end
		return false
	end
	#
	def exec_command name, argument
		abort "#{name}の引数がありません。" if argument.include?(nil)
		# Array#shiftなどは、要素が無いときはnilを返すのでそれを見つける
		exe_shell = "git #{name} #{argument.map{|a| %!"#{a}"! }.join(" ")}"
		puts "\n"+exe_shell
		puts "\t"+command(exe_shell)
		return_num = $?.to_i
		abort "#{name}に失敗しました。" unless return_num==0
	end
end

def current_branch
	command("git rev-parse --abbrev-ref HEAD").chomp
end

# この関数群を動き回って処理していく
def start commands, target
	while commands.length > 0
		case
		when commands[0..1].join("") == "nb"
			p :nb
			exit
		when commands[0] == "c"
			checkouts(commands, target)
		when commands[0] == "m"
			merges(commands, target)
		when commands[0] == "s"
			Cmd.sync(commands)
		when commands[0] == "d"
			Cmd.delete_branch(commands, target.shift)
		when commands[0] == "-"
			commands.shift
		else
			abort "コマンドが不明です'#{commands.join}'"
		end
	end
	"処理が終了した際にターゲットが残っています。'#{target}'" if target.length > 0
end
# チェックアウトの後にいろいろする場合
def checkouts input, target
	start_branch = current_branch
	
	Cmd.checkout(input, target.shift)
	Cmd.merge_ff(input, start_branch)
	Cmd.merge_squash(input, start_branch)
	Cmd.merge(input, start_branch)
	is_deleted = Cmd.delete_branch(input, start_branch)
	Cmd.sync input
	Cmd.checkout(input, start_branch) unless is_deleted
end
# マージの後にいろいろする場合
def merges input, target
	merge_target = target.shift
	
	Cmd.merge_ff(input, merge_target)
	Cmd.merge_squash(input, merge_target)
	Cmd.merge(input, merge_target)
	Cmd.delete_branch(input, merge_target)
end

# 起動用
input = ARGV.shift.split("")
start(input, ARGV)
