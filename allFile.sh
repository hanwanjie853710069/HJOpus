#!/bin/bash

git add --all

git commit -m "提交代码"

echo "请选择要提交的分支"

echo "1 - main"

echo "2 - main"

read describe

tempbarch="main"

if [ $describe == 1 ]
then
tempbarch="main"
fi

git pull origin $tempbarch

git push origin $tempbarch

git push origin --delete tag 1.0

git tag -d 1.0

git tag "1.0"

git push --tag

pod spec lint HJOpus.podspec --verbose --allow-warnings

pod trunk push HJOpus.podspec --verbose --allow-warnings
