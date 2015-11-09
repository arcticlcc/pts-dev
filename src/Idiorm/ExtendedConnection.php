<?php
namespace Idiorm;

use Doctrine\DBAL\Connection AS Connection;

class ExtendedConnection extends Connection {
    public function getAttribute($attr) {
        $conn = $this->getWrappedConnection();
        return $conn->getAttribute($attr);
    }

}
