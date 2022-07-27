echo "=====:: Tokopedia Docker ::====="
echo $t

export RUBYOPT="-W0"
export BROWSER=chrome_headless
export TZ='Asia/Jakarta'
bundle install

cp .env.sample .env
ls

bundle exec rake klikpajak:parallel_run
TEST_EXIT_CODE=$?
if [ $TEST_EXIT_CODE -ne 0 ]
then
  echo "=====:: Tokopedia FAILED !!! ::====="
  echo $TEST_EXIT_CODE
  exit 1
fi
