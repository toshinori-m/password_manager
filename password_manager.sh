#!/bin/bash
echo "パスワードマネージャーへようこそ！"

file="password.txt"

add_password() {
  echo # スペースを入れるためにechoを入れています。
  get_input "サービス名を入力してください：" service_name
  get_input "ユーザー名を入力してください：" user_name
  get_input "パスワードを入力してください：" password
  
  echo "$service_name:$user_name:$password" >> "$file"
  
  if [ $? -eq 0 ]; then
    echo -e "\nパスワードの追加は成功しました。"
  else
    echo "ファイルの保存に失敗しました。"
  fi
}

get_input() {
  local prompt="$1"
  local var_name="$2"

  while true; do
    read -p "$prompt" input_value
    if [ -n "$input_value" ]; then
      eval "$var_name=\$input_value" # get_inputの第二引数にinput_valueの値を格納したいため、evalを使用して変数が展開しコマンド実行する。
      break
    else
      echo "入力を確認できませんでしたので、再度入力してください"
    fi
  done
}

get_password() {
  if [ ! -f "$file" ]; then
    touch "$file"
  fi
  
  echo # スペースを入れるためにechoを入れています。
  read -p "サービス名を入力してください：" service_name
  searchResults=$(awk -F':' -v service="$service_name" '$1 == service' "$file")
  if [ -n "$searchResults" ]; then
    while IFS=$':' read service user pass; do
      echo # スペースを入れるためにechoを入れています。
      echo "サービス名：" $service
      echo "ユーザー名：" $user
      echo "パスワード：" $pass
    done <<< "$searchResults"
  else
    echo -e "\nそのサービスは登録されていません。"
  fi
}

while true; do
  read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" selectOption
  
  case "$selectOption" in
    "Add Password")
      add_password
      ;;
    
    "Get Password")
      get_password
      ;;
      
    "Exit")
      echo -e "\nThank you!"
      break
      ;;
    
    *)
      echo -e "\n入力が間違えています。Add Password/Get Password/Exit から入力してください。"  
      ;;
      
  esac
done
