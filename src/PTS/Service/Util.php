<?php

namespace PTS\Service;

/**
 * A quick and dirty service to provide some utility functions.
 * 
 * @version .1
 * @author Joshua Bradley <joshua_bradley@fws.gov>
 */

class Util 
{

   public function getPDOConstantType( $var )
    {
        if( is_int( $var ) )
            return \PDO::PARAM_INT;
        if( is_bool( $var ) )
            return \PDO::PARAM_BOOL;
        if( is_null( $var ) )
            return \PDO::PARAM_NULL;
        //Default  
        return \PDO::PARAM_STR;
    }
        
} 
 
?>
