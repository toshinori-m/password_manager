#!/bin/bash
echo "パスワードマネージャーへようこそ！"
file="password.txt"

while true
do
read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" selectOption

case "$selectOption" in
  "Add Password")
    read -p "サービス名を入力してください：" service_name
    read -p "ユーザー名を入力してください：" user_name
    read -p "パスワードを入力してください：" password
    echo "$service_name:$user_name:$password" >> "$file"
    if [ $? -eq 0 ]
      then
        echo -e "\nパスワードの追加は成功しました。"
    else
      echo "ファイルが存在しません"
    fi
    ;;
  
  "Get Password")
    read -p "サービス名を入力してください：" service_name
    searchResults=$(grep "^$service_name:" "$file")
    if [ -z "$searchResults" ]
      then
        echo -e "\nそのサービスは登録されていません。"
    else
      while IFS=$':' read service user pass
      do
        echo
        echo "サービス名：" $service
        echo "ユーザー名：" $user
        echo "パスワード：" $pass
      done <<< "$searchResults"
    fi
    ;;
    
  "Exit")
    echo -e "\nThank you!"
    break
    ;;
  
  *)
    echo -e "\n入力が間違えています。Add Password/Get Password/Exit から入力してください。"  
esac
done
