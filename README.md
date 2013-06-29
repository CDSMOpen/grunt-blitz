# grunt-blitz

## Load Testing From The Cloud

### And now from grunt tasks too!

> Run [blitz.io](http://www.blitz.io) sprints and rushes from grunt

## Getting Started
This plugin requires Grunt `~0.4.1`. You'll also need an account with [blitz.io](https://www.blitz.io/signup).

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-blitz --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-blitz');
```

## The "blitz" task

### Overview
In your project's Gruntfile, add a section named `blitz` to the data object passed into `grunt.initConfig()`.

```js
grunt.initConfig({
  blitz: {
    options: {
      // Task-specific options go here.
    },
    your_target: {
      // Target-specific file lists and/or options go here.
    },
  },
})
```

### Options

#### options.blitzid
Type: `String`
Default value: `null`

This should be the email address associated with your blitz.io account.
e.g. `your@email.co.uk`
#### options.blitzkey
Type: `String`
Default value: `null`

This is your blitz.io api key.
e.g. `hedheshi-815the42-15645344-12345678`

N.B. After registering for a [blitz.io](http://www.blitz.io) account, you should be able to find your api details [here](https://www.blitz.io/to#/settings/api_key)

#### options.logPath
Type: `String`
Default value: `null`

Optional path to a log file.

#### options.blitz
Type: `String`
Default value: `null`

The blitz.io test you wish to run. For details, look [here](https://www.blitz.io/docs)

e.g. `-r ireland http://www.bbc.co.uk`


### Usage Examples

In this example, we're setting two blitz tests. The first is a simple sprint that checks that www.somepage.co.uk is available from Ireland. The second test is a rush that scales from 1 to 10 concurrent users hitting the site over 100 seconds.

```js
grunt.initConfig({
  blitz: {
    options: {
      blitzid: 'your@email.co.uk',
      blitzkey: 'hedheshi-815the42-15645344-12345678',
       logPath: 'logs/results.log'
    },
    sprint: {
      blitz: '-r ireland http://www.somepage.co.uk',
    },
    rush: {
      blitz: '-r ireland -p 1-10:100 http://www.somepage.co.uk'
    }
  },
})
```

You can then run either blitz test with:

```shell
grunt blitz:sprint
```
or
```shell
grunt blitz:rush
```

**Warning:** Don't run `grunt blitz` when you have defined multiple tests without specifiying a specific target task as this may result in spamming the blitz.io api and earn you a slap on the wrist.

#### Authenticating with Blitz.io
It's probably not a great idea to store your api credentials in the Gruntfile. as an alternative you can omit them from the Gruntfile and pass them in at the command line instead:
```shell
grunt blitz:sprint --blitzid your@email.co.uk --blitzkey blah-blah-blah-blah
```

## Contributing
Develop in coffee script. Run ```grunt``` to start the compile and test watch processes for convenient TDD. Run ```grunt build``` to test and compile the source before packaging.

Oh yeah, use [Git Flow](https://github.com/nvie/gitflow) - you know it makes sense :)

In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
1.0.0 - First release. Whoop!
1.1.0 - Added AppDex support
