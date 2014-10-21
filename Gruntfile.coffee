'use strict'

module.exports = (grunt) ->

  require('load-grunt-tasks')(grunt, pattern: ['grunt-*', 'grunt-contrib-*'])

  grunt.initConfig
    app: 'src',
    dist: 'dist'

    watch:
      coffee:
        files: ['**/*.coffee'],
        tasks: ['coffee:server', 'uglify:server', 'copy:server']
      livereload:
        options:
          livereload: '<%= connect.options.livereload %>'
        files: ['examples/{,*/}*.html']

    connect:
      options:
        port: 9000
        hostname: 'localhost'
        livereload: 35729
      livereload:
        options:
          base: ['.tmp', 'examples']

    coffee:
      options:
        sourceMap: true
        sourceRoot: ""
      server:
        files: [
          expand: true
          cwd: '<%= app %>'
          src: ['**/*.coffee']
          dest: '.tmp/<%= dist %>'
          # we need this rename function in case files are named
          # with dot notation. e.g., ngm.module.coffee
          rename: (destBase, destPath) ->
              destBase + '/' + destPath.replace(/\.coffee$/, '.js')
        ]
      dist:
        options:
          sourceMap: false
        files: [
          expand: true
          cwd: '<%= app %>'
          src: ['**/*.coffee']
          dest: '<%= dist %>'
          # we need this rename function in case files are named
          # with dot notation. e.g., ngm.module.coffee
          rename: (destBase, destPath) ->
              destBase + '/' + destPath.replace(/\.coffee$/, '.js')
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
      server:
        options:
          beautify: true
        files:
          '.tmp/dist/pivot.all.min.js': [
            '.tmp/dist/pivot.core.js',
            '.tmp/dist/pivot.ui.js',
            '.tmp/dist/renderers/*.js',
            '.tmp/dist/aggregators/templates/*.js',
            '.tmp/dist/aggregators/*.js'
          ]
      dist:
        files:
          '<%= dist %>/pivot.all.min.js': [
            '<%= dist %>/pivot.core.js',
            '<%= dist %>/pivot.ui.js',
            '<%= dist %>/renderers/*.js',
            '<%= dist %>/aggregators/templates/*.js',
            '<%= dist %>/aggregators/*.js'
          ]

    clean:
      server: '.tmp'
      dist: 'dist'

    copy:
      server:
        files: [
          expand: true
          cwd: '<%= app %>'
          src: ['**']
          dest: '.tmp/<%= dist %>/'
        ]


  grunt.registerTask 'serve', 'Compile then start a connect web server', ->
    grunt.task.run [
      'clean:server'
      'concurrent:server'
      'uglify:server'
      'connect:livereload'
      'copy:server'
      'watch'
    ]

  grunt.registerTask 'build', 'Compile and place files in the dist folder', ->
    grunt.task.run [
      'clean:dist'
      'concurrent:build'
      'cssmin:dist'
      'uglify:dist'
    ]
