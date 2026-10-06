<?php

namespace App\Providers;

use App\Services\Scoring\GpphScorer;
use App\Services\Scoring\KpspScorer;
use App\Services\Scoring\MchatScorer;
use App\Services\Scoring\RuleBasedScoringService;
use App\Services\Scoring\SrqScorer;
use App\Services\Scoring\SdqScorer;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(
            RuleBasedScoringService::class,
            function ($app): RuleBasedScoringService {
                return new RuleBasedScoringService([
                    new KpspScorer(),
                    new MchatScorer(),
                    new GpphScorer(),
                    new SdqScorer(),
                    new SrqScorer(),
                ]);
            }
        );
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}