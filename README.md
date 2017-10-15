# gt
gitのブランチ操作をまとめた感じのやつ。

### コマンド例

`gt cmds master`
masterブランチにカレントブランチをマージして、マージしたブランチを削除。そしてそのままsyncする。

`gt cmc aaa`
aaaブランチにカレントブランチをマージして、戻る。

`gt mfd aaa`
aaaブランチをfast-forwardでマージし、aaaブランチを削除する。

`gt s`
syncのみ。

### 省略コマンドについて

- `-`
	- これで区切る。`c`や`m`等のの後に使うことがある
- `d` ターゲットを1つとる
	- ブランチの削除。`git branch -D`で行うので、使用の際には注意を
- `rnb` ターゲットを1つとる
	- カレントブランチの名前を変更する
- `st`
	- `git branch -A` `git status`を実行
- `s`
	- `git sync`を実行
- `c` ターゲットを一つ取る
	- チェックアウトをする。
	- その後にコマンドが正規表現`(m|mf|ms|)(d|c|)`のように来た場合、それぞれのコマンドをチェックアウト前のブランチをターゲットとして実行する。
- `m` ターゲットを一つ取る
	- `git merge --no-ff`を実行する
	- この後にコマンドが正規表現`(m|mf|ms|)(d|)`のように来た場合、それぞれのコマンドをマージ先のブランチをターゲットとして実行する。
- `mf` ターゲットを一つ取る
	- `git merge --ff`を実行する
	- `m`と同じく、この後にコマンドがが正規表現`(m|mf|ms|)(d|)`のように来た場合、それぞれのコマンドをマージ先のブランチをターゲットとして実行する。
- `ms` ターゲットを一つ取る
	- `git merge ----squash`を実行する
	- `m`と同じく、この後にコマンドが正規表現`(m|mf|ms|)(d|)`のように来た場合、それぞれのコマンドをマージ先のブランチをターゲットとして実行する。
- `nb` ターゲットを一つ取る
	- カレントブランチからターゲットの名前のブランチを一つ作る。
	- この後に`c`が来た場合、新しく作ったブランチをターゲットとして実行する


### その他
できるだけ自分に使い心地のいい仕様を目指しているので、一部変な点もあるかもしれないです。

ブランチの削除は-Dで行うので、気をつけてください。
