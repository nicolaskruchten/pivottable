'use strict'

module.exports = (grunt) ->

  require('load-grunt-tasks')(grunt, pattern: ['grunt-*', 'grunt-contrib-*'])

  grunt.initConfig
    app: 'src',
    dist: 'dist'

    watch:
      coffee:
        files: ['**/*.coffee'],
        tasks: ['coffee']
      livereload:
        options:
          livereload: '<%= connect.options.livereload %>'
        files: ['examples/{,*/}*.html']

    connect:
      options:
        port: 9000
        hostname: 'localhost',
        livereload: 35729
      livereload:
        options:
          base: ['.tmp', 'examples']

    coffee:
      server:
        files: [
          expand: true
          cwd: '<%= app %>'
          src: ['{,*/}*.coffee']
          dest: '.tmp/<%= dist %>'
          ext: '.js'
        ]
      dist:
        files: [
          expand: true
          cwd: '<%= app %>'
          src: ['{,*/}*.coffee']
          dest: '<%= dist %>'
          ext: '.js'
        ]

    stylus:
      server:
        options:
          compress: false
        files:
          '.tmp/<%= dist %>/css/pivot.css': ['<%= app %>/styles/{,*/}*.styl']
      dist:
        options:
          compress: false
        files:
          '<%= dist %>/css/pivot.css': ['<%= app %>/styles/{,*/}*.styl']

    concurrent:
      server: [
        'stylus:server'
        'coffee:server'
      ]
      build: [
        'stylus:dist'
        'coffee:dist'
      ]

    cssmin:
      dist:
        files:
          '<%= dist %>/css/pivot.min.css': '<%= dist %>/css/pivot.css'

    uglify:
      dist:
        files:
          '<%= dist %>/pivot-all.min.js': ['<%= dist %>/pivot.js', '<%= dist %>/{aggregators,renderers}/*.js']

    clean:
      server: '.tmp'
      dist: 'dist'


  grunt.registerTask 'serve', 'Compile then start a connect web server', ->
    grunt.task.run [
      'clean:server'
      'concurrent:server'
      'connect:livereload'
      'watch'
    ]

  grunt.registerTask 'build', 'Compile and place files in the dist folder', ->
    grunt.task.run [
      'clean:dist'
      'concurrent:build'
      'cssmin:dist'
      'uglify:dist'
    ]
