Csv Parser
================

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)
[![Build Status](https://travis-ci.org/stephancom/csv-parser.svg?branch=master)](https://travis-ci.org/stephancom/csv-parser)
This application was built in fulfillment of a code test, spec as follows:

# Stock Items Importer / Exporter

Create an importer/exporter which accepts stock item data in csv format and exports it as JSON. It needs to handle stock items and csv -> JSON, but we expect to have other models and formats very soon, and so it should be easy to extend in this way.

Along with a number of standard parameters, stock items are assigned a ‘price_type’ and may have 0 or more ‘modifiers’. A price type of ‘system’ means that the price is set by the store owner ahead of time, a price type of ‘open’ means that it is set at the time of the sale (for example, delivery is not a pre-defined price, it varies at the time of sale). Modifiers are simply alterations to the item being sold which include a price, like a small coffee being less expensive than a large coffee.

This should be coded as if it were being added to a large scale production system and should be representative of the type of work you would submit to such a system and be proud of. Feel free to include a writeup with your submission explaining the design, or outlining any assumptions you made while building it.

### Example Input

```csv
item id,description,price,cost,price_type,quantity_on_hand,modifier_1_name,modifier_1_price,modifier_2_name,modifier_2_price,modifier_3_name,modifier_3_price
111010,Coffee,$1.25,$0.80,system,100000,Small,-$0.25,Medium,$0.00,Large,$0.30
111784,Delivery,,,open
111022,Bagel,$3.45,$2.00,system,9855,Cream Cheese,$1.00
2847224,Orange Juice 48,$68.57,,system,0,Small,$0.00,Medium,$1.00,Large,$2.50
2847225,Milk 49,$70.00,49,system,510
2847226,Ciabatta 50,$71.43,,system,0
2847227,baguette 51,$0.00,,open,0
2847228,Sour Dough Boule 52,$74.29,,system,0
2847244,Whole Coffee Cake 68,$0.00,,open,0
2847229,Country Wht Boule 53,$75.71,,system,0
2847230,Semolina Batard 54,$77.14,,system,0
2847231,Multigrain Batard 55,$78.57,,system,0
2847232,Focaccia 56,$80.00,56,system,440
2847233,Rolls 57,$81.43,,system,0,Jelly,$.75,Peanut Butter,$1.12
```

### Example Output

```JSON
[
  {
    id: 111010,
    description: 'Coffee',
    price: 1.25,
    cost: 0.80,
    price_type: 'system',
    quantity_on_hand: 100000,
    modifiers: [
      {
        name: 'Small',
        price: -0.25
      },{
        name: 'Medium',
        price: 0.00
      },{
        name: 'Large',
        price: 0.30
      }
    ]
  },{
    id: 111784,
    description: 'Delivery'
    price: nil,
    cost: nil,
    price_type: 'open',
    quantity_on_hand: nil,
    modifiers: []
  },
  .
  .
  .
]
```

Development Notes
-------------

I decided to make this a full Rails app primarily because it's more convenient for setting everything up.  I also thought it might be nice to store a history of previous data, allowing for redownload in a different format.

Plans for what I'm going to do (this is being written at the start)
* DSL for describing parsing/output
  * extensible architecture, fields provided include
    * id (unique integer)
    * integer
    * currency (i18n? yeah, right, TODO)
    * string
    * "mutable price"? (includes price/cost/type)
  * selectable parser on input
* Some validation of input
  * possibly saving invalid rows to a "failures" field?
  * or trying to match/correct malformed input? naah.
* XML and YAML format in addition to JSON.  
  * Drawn from the model
  * Dataset.to(:json), etc., with metaprogramming for Dataset.to_json
  * sent with send_file, disposition download, suggest filename
  * probably not cacheing the result
    ** but maybe a serialized field with the hash would not be so bad 
* in real life would perhaps require background processing, probably skipping that.
  * but I've done it before, so maybe not ;)
  * Resque/Sidekick/delayed_job

Ruby on Rails
-------------

This application requires:

- Ruby 2.2.4
- Rails 4.2.5.1

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).

Getting Started
---------------

= Local setup

* clone repository
* bundle
* set up database.yml
* rake db:setup

= Heroku setup steps

```
heroku create [OPTIONAL SERVER NAME]
git push heroku master
heroku run rake db:migrate
heroku run rake db:seed
heroku open
```

Documentation and Support
-------------------------

Issues
-------------

Similar Projects
----------------

Contributing
------------

Credits
-------

```
by: _            _
 __| |_ ___ _ __| |_  __ _ _ _    __ ___ _ __
(_-<  _/ -_) '_ \ ' \/ _` | ' \ _/ _/ _ \ '  \
/__/\__\___| .__/_||_\__,_|_||_(_)__\___/_|_|_|
           |_|              stephan@stephan.com
```

Rails Composer
-------

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem
provided by the [RailsApps Project](http://railsapps.github.io/).

Rails Composer is supported by developers who purchase our RailsApps tutorials.

Problems? Issues?
-----------

Need help? Ask on Stack Overflow with the tag 'railsapps.'

Your application contains diagnostics in the README file. Please provide a copy of the README file when reporting any issues.

If the application doesn't work as expected, please [report an issue](https://github.com/RailsApps/rails_apps_composer/issues)
and include the diagnostics.

License
-------


