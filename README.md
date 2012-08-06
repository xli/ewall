EWall
======================

EWall is a tool to track and digitalize your card wall.

Install
----------------------

* Install OpenCV 2.4+
* Install opencv ruby binding from git://github.com/ruby-opencv/ruby-opencv.git
* bundle install

Launch Application
---------------------

    export RAILS_ENV=production
    rake db:migrate
    ./script/delayed_job start
    nohup rails s  > /dev/null 2>&1 &

License
---------------------

You may use the EWall under the MIT License.
