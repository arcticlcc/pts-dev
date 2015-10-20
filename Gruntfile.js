module.exports = function(grunt) {

  grunt.initConfig({

    sencha_dependencies : {
      dist : {
        options : {
          pageRoot : './web/pts', // relative to dir where grunt will be run
          appJs : 'app.js', // relative to www
          pageToProcess : 'build.html', // relative to www
          exclude : ['./extjs/ext-debug.js']
        }
      }
    },
    /**
     * Clean
     *
     * Before generating any new files, remove any previously-created output files.
     */
    clean : {
      build : ["build"]
    },

    /**
     * JSHint
     *
     * Validate the source code files to ensure they follow our coding convention and
     * don"t contain any common errors.
     */
    jshint : {
      all : ["Gruntfile.js", "web/pts/app/**/*.js", "web/pts/app.js"],
      options : {
        jshintrc : ".jshintrc"
      }
    },
    /**
     * Uglify.js
     *
     * Concatenates & minifies the source code files. In addition we create a source map
     * so that in Chrome & FF we can debug with the source files in production.
     * Write the output file to our "build/www" directory
     */
    uglify : {
      build : {
        options : {
          sourceMap : "web/pts/source-map.map",
          sourceMappingURL : "./pts/source-map.map",
          sourceMapRoot : ".."
        },
        files : {
          "web/pts/app-all.min.js" : ["<%= sencha_dependencies_dist %>"]
        }
      }
    },
    cssmin : {
      options : {
        shorthandCompacting : false,
        roundingPrecision : -1,
        sourceMap: true
      },
      target : {
        files : {
          'web/pts/resources/css/pts.min.css' : [
          'web/pts/extjs/resources/css/ext-all.css',
          'web/pts/extensible-1.5.1/resources/css/extensible-all.css',
          'web/pts/resources/css/pts.css',
          'web/pts/lib/highlight/src/styles/github.css'
          ]
        }
      }
    }
    /**
     * Copy
     *
     * Any additional files our project still needs to run with in to the "build/www" directory
     * This includes CSS, images, mock data and our index.html
     * Note that we also do some replacement on the index.html to point it to our new
     * concat"d/minified JS file.
     */
    /*copy : {
    build : {
    files : [{
    expand : true,
    src : ["ext-4.1.1a/resources/css/ext-all.css"],
    dest : "build/www",
    cwd : "www"
    }, {
    expand : true,
    src : ["ext-4.1.1a/resources/themes/images/**"],
    dest : "build/www",
    cwd : "www"
    }, {
    expand : true,
    src : ["data/**"],
    dest : "build/www",
    cwd : "www"
    }, {
    expand : true,
    src : ["index.html"],
    dest : "build/www",
    cwd : "www"
    }],*/
    //options : {
    //processContentExclude : ["**/*.{gif,jpg,png}"],
    //processContent : function(content, filePath) {
    /*if (/index.html/.test(filePath)) {
    // remove the ext script
    content = content.replace(/<script.*ext.js"><\/script>/, "");
    // now update the css location
    content = content.replace(/\.\.\/libs\/ext-4.1.1a\//, "");
    return content.replace(/app\/app.js/, "app.min.js");
    }
    return content;
    }
    }*/
    //}
    //},
  });

  grunt.loadNpmTasks('grunt-sencha-dependencies');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks("grunt-contrib-jshint");
  grunt.loadNpmTasks("grunt-contrib-uglify");
  grunt.loadNpmTasks("grunt-contrib-clean");
  grunt.loadNpmTasks("grunt-contrib-copy");

  grunt.registerTask('dep', ['sencha_dependencies']);
  grunt.registerTask('default', ['jshint', 'dep', 'uglify']);
  grunt.registerTask('prod', ['default','cssmin']);

};
