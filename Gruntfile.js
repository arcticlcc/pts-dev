module.exports = function(grunt) {

    grunt.initConfig({

        sencha_dependencies: {
            dist: {
                options: {
                    pageRoot: './web/pts', // relative to dir where grunt will be run
                    appJs: 'app.js', // relative to www
                    pageToProcess: 'buildtemp.html', // relative to www
                    exclude: []
                }
            }
        },
        /**
         * Clean
         *
         *  Remove output files.
         */
        clean: {
            build: ["build", "web/pts/buildtemp.html"],
            wget: ["web/pts/buildtemp.html"]
        },

        /**
         * JSHint
         *
         * Validate the source code files to ensure they follow our coding convention and
         * don"t contain any common errors.
         */
        jshint: {
            all: ["Gruntfile.js", "web/pts/app/**/*.js", "web/pts/app.js"],
            options: {
                jshintrc: ".jshintrc"
            }
        },
        /**
         * Uglify.js
         *
         * Concatenates & minifies the source code files. In addition we create a source map
         * so that in Chrome & FF we can debug with the source files in production.
         * Write the output file to our "build/www" directory
         */
        uglify: {
            buildapp: {
                options: {
                    sourceMap: "web/pts/source-map.map",
                    sourceMappingURL: "./pts/source-map.map",
                    sourceMapRoot: ".."
                },
                files: {
                    "web/pts/app-all.min.js": ["<%= sencha_dependencies_dist_app %>"]
                }
            },
            buildext: {
                options: {
                    sourceMap: "web/pts/ext-map.map",
                    sourceMappingURL: "./pts/ext-map.map",
                    sourceMapRoot: ".."
                },
                files: {
                    "web/pts/ext.min.js": ["<%= sencha_dependencies_dist_ext_core %>"]
                }
            }
        },
        cssmin: {
            options: {
                shorthandCompacting: false,
                roundingPrecision: -1,
                sourceMap: true
            },
            target: {
                files: {
                    'web/pts/resources/css/pts-all.min.css': [
                        'web/pts/extjs/resources/css/ext-all.css',
                        'web/pts/lib/extensible/resources/css/calendar.css',
                        'web/pts/lib/extensible/resources/css/calendar-colors.css',
                        'web/pts/resources/css/pts.css',
                        'web/pts/lib/highlight/src/styles/github.css',
                        'web/pts/lib/openlayers/theme/default/style.css'
                    ]
                }
            }
        },

        jsbeautifier: {
            "default": {
                src: ["web/pts/app/**/*.js", "web/pts/app.js", "Gruntfile.js"]
            },
            "git-pre-commit": {
                src: ["web/pts/app/**/*.js", "web/pts/app.js", "Gruntfile.js"],
                options: {
                    mode: "VERIFY_ONLY"
                }
            }
        },

        jsduck: {
            main: {
                // source paths with your code
                src: [
                    //"web/pts/extjs",
                    "web/pts/app.js",
                    "web/pts/app",
                    "web/pts/ux"
                ],

                // docs output dir
                dest: 'web/pts/docs',

                // extra options
                options: {
                    'builtin-classes': true,
                    'warnings': ['-no_doc', '-dup_member', '-link_ambiguous'],
                    'title': 'PTS Docs'
                }
            }
        },
        /**
         * Copy
         *
         * Any additional files our project still needs to run with in to the "build/www" directory
         * This includes CSS, images, mock data and our index.html
         * Note that we also do some replacement on the index.html to point it to our new
         * concat"d/minified JS file.
         */

        copy: {
            build: {
                files: [{
                    expand: true,
                    src: ["**/*"],
                    dest: "web/pts/resources/themes/images",
                    cwd: "web/pts/extjs/resources/themes/images"
                }, {
                    expand: true,
                    src: ["**/*"],
                    dest: "web/pts/resources/images",
                    cwd: "web/pts/lib/extensible/resources/images"
                }, {
                    expand: true,
                    src: ["**/*",  "!**/*(layer-switcher-maximize.png)"],
                    dest: "web/pts/resources/images/ol",
                    cwd: "web/pts/lib/openlayers/img"
                }]
            }
        },

        wget: {
            build: {
                files: {
                    'web/pts/buildtemp.html': 'http://localhost:81/pts/build'
                }
            }
        }
    });

    grunt.loadNpmTasks('grunt-sencha-dependencies');
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks("grunt-contrib-jshint");
    grunt.loadNpmTasks("grunt-contrib-uglify");
    grunt.loadNpmTasks("grunt-contrib-clean");
    grunt.loadNpmTasks("grunt-contrib-copy");
    grunt.loadNpmTasks("grunt-jsbeautifier");
    grunt.loadNpmTasks('grunt-jsduck');
    grunt.loadNpmTasks('grunt-wget');

    grunt.registerTask('dep', ['wget:build', 'sencha_dependencies', 'clean:wget']);
    grunt.registerTask('default', ['jshint', 'dep', 'uglify']);
    grunt.registerTask('build', ['clean:build', 'default', 'cssmin', 'copy']);

};
