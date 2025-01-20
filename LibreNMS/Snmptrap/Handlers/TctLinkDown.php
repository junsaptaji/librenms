<?php

namespace LibreNMS\Snmptrap\Handlers;

use App\Models\Device;
use LibreNMS\Interfaces\SnmptrapHandler;
use LibreNMS\Snmptrap\Trap;
use Log;

class TctLinkDown implements SnmptrapHandler
{
    /**
     * Handle snmptrap.
     * Data is pre-parsed and delivered as a Trap.
     *
     * @param  Device  $device
     * @param  Trap  $trap
     * @return void
     */
    public function handle(Device $device, Trap $trap)
    {
        $rxPower = $trap->getOidData('TCT-SNMP-MIB::tctSnmpRxPwr');
        Log::event('TCT: Laser link DOWN. Rx Power: ' . $rxPower, $device->device_id, 'trap', 5);
    }
}
