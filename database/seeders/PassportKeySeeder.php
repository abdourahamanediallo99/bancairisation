<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class PassportKeySeeder extends Seeder
{
    public function run()
    {
        $privatePath = storage_path('oauth-private.key');
        $publicPath = storage_path('oauth-public.key');

        if (File::exists($privatePath) && File::exists($publicPath)) {
            DB::table('oauth_clients')
                ->where('id', 1)
                ->update([
                    'private_key' => File::get($privatePath),
                    'public_key' => File::get($publicPath),
                ]);
        }
    }
}
