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
    rails s
    ./script/delayed_job start

License
---------------------

You may use the EWall under the MIT License.
